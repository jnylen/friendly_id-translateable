require 'i18n'

module FriendlyId

=begin

== Translating Slugs Using Translateable

The {FriendlyId::Translateable Translateable} module lets you use
Translateable[https://github.com/olegantonyan/translateable] to translate slugs. This
module is most suitable for applications that need to be localized to many
languages. If your application only needs to be localized to one or two
languages, you may wish to consider the {FriendlyId::SimpleI18n SimpleI18n}
module.

In order to use this module, your model's table and translation table must both
have a slug column, and your model must set the +slug+ field as translatable
with Translateable:

    class Post < ActiveRecord::Base
      translates :title, :slug
      extend FriendlyId
      friendly_id :title, :use => :Translateable
    end

=== Finds

Finds will take the current locale into consideration:

  I18n.locale = :it
  Post.find("guerre-stellari")
  I18n.locale = :en
  Post.find("star-wars")

Additionally, finds will fall back to the default locale:

  I18n.locale = :it
  Post.find("star-wars")

To find a slug by an explicit locale, perform the find inside a block
passed to I18n's +with_locale+ method:

  I18n.with_locale(:it) { Post.find("guerre-stellari") }

=== Creating Records

When new records are created, the slug is generated for the current locale only.

=== Translating Slugs

To translate an existing record's friendly_id, use
{FriendlyId::Translateable::Model#set_friendly_id}. This will ensure that the slug
you add is properly escaped, transliterated and sequenced:

  post = Post.create :name => "Star Wars"
  post.set_friendly_id("Guerre stellari", :it)

If you don't pass in a locale argument, FriendlyId::Translateable will just use the
current locale:

  I18n.with_locale(:it) { post.set_friendly_id("Guerre stellari") }

=end
  module Translateable
    class << self

      def setup(model_class)
        model_class.friendly_id_config.use :slugged, :finders
      end

      def included(model_class)
        advise_against_untranslated_model(model_class)
      end

      def advise_against_untranslated_model(model)
        field = model.friendly_id_config.query_field
        unless model.respond_to?('translateable_permitted_attributes') ||
               model.translated_attribute_names.exclude?(field.to_sym)
          raise "[FriendlyId] You need to translate the '#{field}' field with " \
            "Translateable (add 'translateable :#{field}' in your model '#{model.name}')"
        end
      end
      private :advise_against_untranslated_model
    end

    def should_generate_new_friendly_id?
      self.send(friendly_id_config.base.to_s + "_changed?")
    end

    def set_slug
      I18n.available_locales.each do |locale|
        ::I18n.with_locale(locale) { super_set_slug(nil) }
      end
    end

    def super_set_slug(normalized_slug = nil)
      if should_generate_new_friendly_id?
        candidates = FriendlyId::Candidates.new(self, normalized_slug || send(friendly_id_config.base))
        slug = slug_generator.generate(candidates) || resolve_friendly_id_conflict(candidates)
        self.slug = slug
      end
    end
  end

  # I have to replace some of these functions due to it working in that way with jsonb
  module FinderMethods
    def exists_by_friendly_id?(id)
      where("#{friendly_id_config.query_field.to_s}->>'#{I18n.locale}' = ?", id).exists?
    end

    def first_by_friendly_id(id)
      locale = I18n.locale || I18n.default_locale
      find_by("#{friendly_id_config.query_field.to_s}->>'#{locale}' = ?", id)
    end
  end
end
