# A module containing constraints that have enumerations of integer 
# operands as left hand side.
module Gecode::Constraints::IntEnum #:nodoc:
  # Describes an integer variable enumeration operand. Classes that mix in
  # IntEnumOperand must define #model and #to_int_enum .
  module IntEnumOperand
    include Gecode::Constraints::Operand 

    def method_missing(method, *args)
      if Gecode::IntEnum.instance_methods.include? method.to_s
        # Delegate to the int enum.
        to_int_enum.method(method).call(*args)
      else
        super
      end
    end

    private

    def construct_receiver(params)
      IntEnumConstraintReceiver.new(@model, params)
    end
  end

  # Describes a constraint receiver for enumerations of integer operands.
  class IntEnumConstraintReceiver < Gecode::Constraints::ConstraintReceiver #:nodoc:
    # Raises TypeError unless the left hand side is an int enum
    # operand.
    def initialize(model, params)
      super

      unless params[:lhs].respond_to? :to_int_enum
        raise TypeError, 'Must have int enum operand as left hand side.'
      end
    end
  end
end

require 'gecoder/interface/constraints/int_enum/distinct'
require 'gecoder/interface/constraints/int_enum/equality'
require 'gecoder/interface/constraints/int_enum/channel'
require 'gecoder/interface/constraints/int_enum/element'
require 'gecoder/interface/constraints/int_enum/count'
require 'gecoder/interface/constraints/int_enum/sort'
require 'gecoder/interface/constraints/int_enum/arithmetic'
require 'gecoder/interface/constraints/int_enum/extensional'
