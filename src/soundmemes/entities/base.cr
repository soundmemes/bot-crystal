module Soundmemes
  module Entities
    abstract struct Base
      macro define_initializer(mapping)
        def initialize(
          {% for key, value in mapping %}
            {% default = value[:default] ? value[:default] : (value[:nilable] || "#{value[:type]}".includes?('?') || "#{value[:type]}".includes?("Nil") ? nil : false) %}
            @{{key.id}} : {{value[:type].id}}{{ '?'.id if value[:nilable] }}{{ " = #{default}".id if default != false }},
          {% end %}
        )
        end
      end

      macro define_properties(mapping)
        {% for key, value in mapping %}
          property {{key.id}}
        {% end %}
      end

      macro mapping(mapping)
        define_properties({{mapping}})
        define_initializer({{mapping}})
      end
    end
  end
end
