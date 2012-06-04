class UIView
  def dataBindings
    @_dataBindings ||= {}
  end

  def outlets
    @_outlets ||= {}
  end

  def setValue(value, forUndefinedKey:key)
    if key == "dataBinding" || key == "outlet"
      raise "Runtime attribute '#{key}' must be a String (declared on #{self.class.name})" unless value.is_a?(String)

      container = self
      while container.superview
        container = container.superview
      end

      if key == "dataBinding"
        unless value.start_with?("model.")
         raise "Data binding expression must start with 'model.'; you provided '#{value}'"
        end

        container.dataBindings[value[6..-1]] = self
      else
        container.outlets[value] = self
      end
    else
      super
    end
  end
end
