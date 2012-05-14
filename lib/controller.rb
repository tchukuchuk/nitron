class Nitron::Controller < UIViewController
  def self.bind(name, opts)
    bindings[name] = opts
  end

  def self.bindings
    @bindings ||= {}
  end

  def viewWillAppear(animated)
    super

    self.class.bindings.each do |name, opts|
      ivar = "@" + name.to_s
      instance_variable_set(ivar.to_sym, self.view.viewWithTag(opts[:tag]))
    end
  end
end
