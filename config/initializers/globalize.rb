module Globalize
  module ActiveRecord
    module InstanceMethods
      def save(*)
        # The original uses `translation.locale` instead of `Globalize.locale`
        # translation.locale loads the translation with empty attributes
        # It both makes the record invalid if there are validations and
        # it makes it almost impossible to create a record with translations
        # which don't include the current locale.
        #
        # Credit for this code belongs to Jack Tomaszewski:
        # https://github.com/globalize/globalize/pull/578
        Globalize.with_locale(Globalize.locale || I18n.default_locale) do
          super
        end
      end
    end
  end
end
