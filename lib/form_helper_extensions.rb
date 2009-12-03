
module ActionView
  module Helpers
    module FormHelper
      def spinbox_field(object_name, method, options = {})
         min_val = options.delete(:min)
         max_val = options.delete(:max)
         tag = InstanceTag.new(object_name, method, self, options.delete(:object)).to_input_field_tag("text", options.merge({:class =>"spin-button"}))
         script = '<script type="text/javascript">new SpinButton($("'
         script += "#{object_name}_#{method}"
         script += '"),{'
         script += "min:#{min_val}" if min_val
         script += "," if min_val and max_val
         script += "max:#{max_val}" if max_val
         script += '});</script>'
         tag+script
      end

    end

    class FormBuilder
      def spinbox_field(method, options = {})
        @template.spinbox_field(@object_name, method, options)
      end
    end
  end
end
