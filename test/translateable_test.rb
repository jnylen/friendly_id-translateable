# encoding: utf-8
require 'bundler/setup'
require 'active_record'
require 'friendly_id'
require 'friendly_id/translateable'
require 'translateable'
require 'minitest/autorun'
require 'spec_helper'

class Module
  def test(name, &block)
    define_method("test_#{name.gsub(/[^a-z0-9']/i, "_")}".to_sym, &block)
  end
end

class TranslateableTest < MiniTest::Unit::TestCase

  def transaction
    ActiveRecord::Base.transaction { yield ; raise ActiveRecord::Rollback }
  end

  def with_instance_of(*args)
    model_class = args.shift
    args[0] ||= {:name => "a b c"}
    transaction { yield model_class.create!(*args) }
  end

  def setup
    I18n.locale = :en
    I18n.available_locales = [:en, :de, :it, :fr, :es]
  end

  test 'should have a value for friendly_id after creation' do
    transaction do
      article = ::I18n.with_locale(:de) { Article.create!(:title => 'Der Herbst des Einsamen') }
      refute_nil article.friendly_id
    end
  end

  test "should find slug in current locale if locale is set, otherwise in default locale" do
    transaction do
      I18n.default_locale = :en
      article_en = I18n.with_locale(:en) { Article.create!(:title => 'a title') }
      article_de = I18n.with_locale(:de) { Article.create!(:title => 'titel') }

      I18n.with_locale(:de) do
        assert_equal Article.friendly.find("titel"), article_de
      end

      assert_equal Article.friendly.find("a-title"), article_en
    end
  end

  test "should set all friendly ids for each nested translation" do
    transaction do
      article = Article.create!(title: {it: 'Guerra e pace', fr: 'Guerre et paix'})
      I18n.with_locale(:it) { assert_equal "guerra-e-pace", article.friendly_id }
      I18n.with_locale(:fr) { assert_equal "guerre-et-paix", article.friendly_id }
    end
  end

  test "check if a translated slug exists" do
    transaction do
      article = Article.create!(title: {de: 'Lidl ist kawai', en: 'Baguette'})
      assert_equal Article.exists?("baguette"), true
      I18n.with_locale(:de) { assert_equal Article.exists?("lidl-ist-kawai"), true }
      I18n.with_locale(:it) { assert_equal Article.exists?("baguette"), true }
    end
  end

  # https://github.com/svenfuchs/Translateable3/blob/master/test/Translateable3/dynamic_finders_test.rb#L101
  # see: https://github.com/svenfuchs/Translateable3/issues/100
  test "record returned by friendly_id should have all translations" do
    transaction do
      I18n.with_locale(:en) do
        article = Article.create!(:title => 'a title')
        I18n.with_locale(:de) {article.title = 'ein titel'}
        article.save!

        article_by_friendly_id = Article.friendly.find("a-title")

        article.title_translateable.each do |translation|
          assert_includes article_by_friendly_id.title_translateable.map(&:data), translation.data
        end
      end
    end
  end
end
