module Gecode
  class FreeSetVar
    Gecode::Constraints::Util::SET_OPERATION_TYPES.each_pair do |name, type|
      module_eval <<-"end_code"
        # Starts a constraint on this set union the specified set.
        def #{name}(operand)
          unless operand.kind_of?(Gecode::FreeSetVar) or 
              Gecode::Constraints::Util::constant_set?(operand)
            raise TypeError, 'Expected set variable or constant set as ' + 
              "operand, got \#{operand.class}."
          end

          params = {:lhs => self, :op2 => operand, :operation => #{type}}
          Gecode::Constraints::SimpleExpressionStub.new(@model, params) do |m, ps|
            Gecode::Constraints::Set::Operation::Expression.new(m, ps)
          end
        end
      end_code
    end
  end
end

module Gecode::Constraints::Set
  # A module that gathers the classes and modules used in relation constraints.
  module Operation
    # An expression with a set operand and two operands followed by must.
    class Expression < Gecode::Constraints::Expression
      Gecode::Constraints::Util::SET_RELATION_TYPES.each_pair do |name, type|
        module_eval <<-"end_code"
          # Creates an operation constraint using the specified expression.
          def #{name}(expression)
            if @params[:negate]
              raise Gecode::MissingConstraintError, 'A negated set operation ' + 
                'constraint is not implemented.'
            end
            unless expression.kind_of?(Gecode::FreeSetVar) or 
                Gecode::Constraints::Util::constant_set?(expression)
              raise TypeError, 'Expected set variable or constant set, got ' + 
                "\#{expression.class}."
            end
            @params[:rhs] = expression
            @params[:relation] = #{type}
            @model.add_constraint OperationConstraint.new(@model, @params)
          end
        end_code
      end
      alias_set_methods
    end
    
    # Describes a constraint involving a set operator operating on two set 
    # operands.
    class OperationConstraint < Gecode::Constraints::Constraint
      def post
        op1, op2, operation, relation, rhs, negate = @params.values_at(:lhs, 
          :op2, :operation, :relation, :rhs, :negate)

        if rhs.respond_to? :bind
          rhs = rhs.bind
        else
          rhs = Gecode::Constraints::Util::constant_set_to_int_set(rhs)
        end
        
        if op2.respond_to? :bind
          op2 = op2.bind
        else
          op2 = Gecode::Constraints::Util::constant_set_to_int_set(op2)
        end

        Gecode::Raw::rel(@model.active_space, op1.bind, operation, op2, 
          relation, rhs)
      end
    end
  end
end