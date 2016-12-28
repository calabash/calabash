Before do
  @state = {}

  class CalabashMethods
    def android?
      @_android ||= ::Kernel.rand(2) == 1
    end

    def ios?
      !android?
    end
  end
end
