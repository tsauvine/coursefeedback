module ApplicationHelper
  
  class ActionView::Helpers::FormBuilder
    # Usage:
    # form_for(@user) do |f|
    #   <%= f.hint :name %>
    def hint(method, options = {})
      if @object && @object.errors[method]
        html = "<span class='error'>#{@object.errors[method].join('. ')}</span>"
        return html.html_safe
      else
        html = '<span class="hint">' + @template.t("#{@object_name}_#{method}_hint") + '</span>'
        return html.html_safe
      end
    end
  end
  
end
