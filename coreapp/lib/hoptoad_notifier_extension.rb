module HoptoadNotifierExtension
  module ClassMethods

    # runs +block+ and notifies hoptoad on exception.
    # returns false if errored, true otherwise.
    def fail_silently(options = {}, &block)
      begin
        yield block
      rescue Exception => e
        logger.error(e.backtrace)
        HoptoadNotifier.notify(e)
        return false
      end
      true
    end

  end  # ClassMethods
end  # HoptoadNotifier
