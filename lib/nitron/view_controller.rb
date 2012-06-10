module Nitron
  class ViewController < UIViewController
    include UI::DataBindingSupport
    include UI::OutletSupport
    include UI::ActionSupport

    def close
      dismissModalViewControllerAnimated(true)
    end
  end
end

