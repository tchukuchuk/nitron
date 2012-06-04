module Nitron
  class ViewController < UIViewController
    include UI::DataBindingSupport
    include UI::OutletSupport

    def close
      dismissModalViewControllerAnimated(true)
    end
  end
end

