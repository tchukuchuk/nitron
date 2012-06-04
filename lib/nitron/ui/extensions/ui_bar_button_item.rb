class UIBarButtonItem
  def setValue(value, forUndefinedKey:key)
    if key == "outlet"
      view.setValue(value, forUndefinedKey:key)
    else
      super
    end
  end
end
