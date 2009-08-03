class Speck
  ##
  # Represents a queued thing to be checked of some sort, within a `Speck`.
  class Check
    ##
    # A block to be executed.
    attr_accessor :lambda
    
    ##
    # A description for the check. Usually a relevant line of code.
    attr_accessor :description
    
    ##
    # The status of the `Check`. `nil` indicates the `Check` hasn’t been
    # executed, and `true` or `false` indicate the success of the latest
    # execution.
    attr_accessor :status
    
    ##
    # Checks the truthiness of this `Check`’s `status`.
    def success?
      !!status
    end
    Speck.new :status do
      object = Object.new
      Check.new(->{true}).execute.status
        .check {|s| s == true}
      Check.new(->{object}).execute.status
        .check {|s| s == object}
      
      Check.new(->{true}).execute.success?.check
      Check.new(->{object}).execute.success?.check
      
      Check.new(->{false}).tap {|c| c.execute rescue nil } .status
        .check {|s| s == false}
      Check.new(->{nil}).tap {|c| c.execute rescue nil } .status
        .check {|s| s == false}
    end
    
    def initialize(lambda, description = "<undocumented>")
      @lambda = lambda
      @description = description
    end
    Speck.new Check, :new do
      my_lambda = ->{}
      Check.new(my_lambda).lambda.check {|l| l == my_lambda }
      
      Check.new(->{}, "WOO! BLANK CHECK!").description
        .check {|d| d == "WOO! BLANK CHECK!" }
    end
    
    ##
    # Executes this `Check`, raising an error if the block returns nil or
    # false.
    def execute
      @lambda.call.tap {|result| @status = result ? result : false }
      raise Exception::CheckFailed unless success?
      self
    end
    Speck.new :execute do
      Check.new(->{true}).execute.check {|c| c.success? }
      ->{ Check.new(->{false}).execute }
        .check_exception Speck::Exception::CheckFailed
      
      Check.new(->{"value"}).execute.check
      Check.new(->{2 * 2}).execute.check {|value| value == 4 }
    end
    
  end
end
