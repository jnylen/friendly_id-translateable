# FriendlyId Translateable

[Translateable](https://github.com/olegantonyan/translateable) support for
[FriendlyId](https://github.com/norman/friendly_id). Copy of the globalize support for friendly_id.

### Translating Slugs Using Translateable
The `FriendlyId::Translateable Translateable` module lets you use
[Translateable](https://github.com/olegantonyan/translateable) to translate slugs. This
module is most suitable for applications that need to be localized to many
languages. If your application only needs to be localized to one or two
languages, you may wish to consider the `FriendlyId::SimpleI18n SimpleI18n`
module.

**NOTE!** This gem currently replaces `exists_by_friendly_id?` and `first_by_friendly_id`
in the finder module in order to be able to find slug in jsonb.

In order to use this module, your model's table and translation table must both
have a slug column, and your model must set the `slug` field as translateable
with Translateable:
```ruby
class Post < ActiveRecord::Base
  translateable :title, :slug
  extend FriendlyId
  friendly_id :title, :use => :translateable
end
```
Note that call to `translateable` must be made before calling `friendly_id`.

### Finds
Finds will take the current locale into consideration:
```ruby
I18n.locale = :it
Post.find("guerre-stellari")
I18n.locale = :en
Post.find("star-wars")
```
To find a slug by an explicit locale, perform the find inside a block
passed to I18n's `with_locale` method:
```ruby
I18n.with_locale(:it) { Post.find("guerre-stellari") }
```
### Creating Records
When new records are created, the slug is generated for all locales.

### Non-existing translations
If no translation has been found for a locale inside the `I18n.available_locales` function then it will pick the one from `I18n.default_locale` and if that isn't added either it will pick the first one in the json.
