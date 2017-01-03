$_picked_android_platform ||= ::Kernel.rand(2) == 1

Before do
  @state = {}

  class CalabashMethods
    def android?
      $_picked_android_platform
    end

    def ios?
      !android?
    end
  end
end
