require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/constraint_helper'

class BoolSampleProblem < Gecode::Model
  attr :b1
  attr :b2
  attr :b3
  
  def initialize
    @b1 = self.bool_var
    @b2 = self.bool_var
    @b3 = self.bool_var
  end
end

describe Gecode::Constraints::Bool do
  before do
    @model = BoolSampleProblem.new
    @b1 = @model.b1
    @b2 = @model.b2
    @b3 = @model.b3
    @operand = @b1 | @b2
    
    # For constraint option spec.
    @invoke_options = lambda do |op, hash| 
      op.must_be.true(hash) 
      @model.solve!
    end
    @expect_options = option_expectation do |op_var, strength, kind, reif_var|
      @model.allow_space_access do
        # We only test the non-MiniModel parts.
        unless reif_var.nil?
          Gecode::Raw.should_receive(:rel).once.with(
            an_instance_of(Gecode::Raw::Space), 
            op_var, Gecode::Raw::IRT_EQ, 
            an_instance_of(Gecode::Raw::BoolVar), strength, kind)
        end
      end
    end
  end

  it 'should handle single variables constrainted to be true' do
    @b1.must_be.true
    b1 = @model.solve!.b1
    b1.should be_assigned
    b1.value.should be_true
  end
  
  it 'should handle single variables constrainted to be false' do
    @b1.must_be.false
    b1 = @model.solve!.b1
    b1.should be_assigned
    b1.value.should_not be_true
  end
  
  it 'should handle single variables constrainted not to be false' do
    @b1.must_not_be.false
    b1 = @model.solve!.b1
    b1.should be_assigned
    b1.value.should be_true
  end
  
  it 'should handle single variables constrainted not to be true' do
    @b1.must_not_be.true
    b1 = @model.solve!.b1
    b1.should be_assigned
    b1.value.should_not be_true
  end

  it 'should handle disjunction' do
    @b1.must_be.false
    (@b1 | @b2).must_be.true
    sol = @model.solve!
    sol.b1.value.should_not be_true
    sol.b2.value.should be_true
  end

  it 'should handle negated disjunction' do
    @b1.must_be.false
    (@b1 | @b2).must_not_be.true
    sol = @model.solve!
    sol.b1.value.should_not be_true
    sol.b2.value.should_not be_true
  end

  it 'should handle conjunction' do
    (@b1 & @b2).must_be.true
    sol = @model.solve!
    sol.b1.value.should be_true
    sol.b2.value.should be_true
  end

  it 'should handle negated conjunction' do
    @b1.must_be.true
    (@b1 & @b2).must_not_be.true
    sol = @model.solve!
    sol.b1.value.should be_true
    sol.b2.value.should_not be_true
  end

  it 'should handle exclusive or' do
    @b1.must_be.false
    (@b1 ^ @b2).must_be.true
    sol = @model.solve!
    sol.b1.value.should_not be_true
    sol.b2.value.should be_true
  end

  it 'should handle negated exclusive or' do
    @b1.must_be.true
    (@b1 ^ @b2).must_not_be.true
    sol = @model.solve!
    sol.b1.value.should be_true
    sol.b2.value.should be_true
  end
  
  it 'should handle implication' do
    @b2.must_be.false
    (@b1.implies @b2).must_be.true
    sol = @model.solve!
    sol.b1.value.should_not be_true
    sol.b2.value.should_not be_true
  end
  
  it 'should handle negated implication' do
    @b1.must_be.true
    ((@b1 | @b2).implies @b2).must_not_be.true
    sol = @model.solve!
    sol.b1.value.should be_true
    sol.b2.value.should_not be_true
  end
  
  it 'should handle imply after must' do
    @b2.must_be.false
    @b1.must.imply @b2
    sol = @model.solve!
    sol.b1.value.should_not be_true
    sol.b2.value.should_not be_true
  end

  it 'should handle imply after must_not' do
    @b1.must_be.true
    @b1.must_not.imply @b2
    sol = @model.solve!
    sol.b1.value.should be_true
    sol.b2.value.should_not be_true
  end

  it 'should handle single variables as right hand side' do
    @b1.must == @b2
    @b2.must_be.false
    sol = @model.solve!
    sol.b1.value.should_not be_true
    sol.b2.value.should_not be_true
  end
  
  it 'should handle single variables with negation as right hand side' do
    @b1.must_not == @b2
    @b2.must_be.false
    sol = @model.solve!
    sol.b1.value.should be_true
    sol.b2.value.should_not be_true
  end

  it 'should handle expressions as right hand side' do
    @b1.must == (@b2 | @b3)
    @b2.must_be.true
    sol = @model.solve!
    sol.b1.value.should be_true
    sol.b2.value.should be_true
  end

  it 'should handle nested expressions as left hand side' do
    ((@b1 & @b2) | @b3 | (@b1 & @b3)).must_be.true
    @b1.must_be.false
    sol = @model.solve!
    sol.b1.value.should_not be_true
    sol.b3.value.should be_true
  end

  it 'should handle nested expressions on both side' do
    ((@b1 & @b1) | @b3).must == ((@b1 & @b3) & @b2)
    @b1.must_be.true
    sol = @model.solve!
    sol.b1.value.should be_true
    sol.b2.value.should be_true
    sol.b3.value.should be_true
  end

  it 'should handle nested expressions with implication' do
    ((@b1 & @b1) | @b3).must.imply(@b1 ^ @b2)
    @b1.must_be.true
    sol = @model.solve!
    sol.b1.value.should be_true
    sol.b2.value.should be_false
  end

  it 'should handle nested expressions containing exclusive or' do
    ((@b1 ^ @b1) & @b3).must == ((@b2 | @b3) ^ @b2)
    @b1.must_be.true
    @b2.must_be.false
    sol = @model.solve!
    sol.b1.value.should be_true
    sol.b2.value.should_not be_true
    sol.b3.value.should_not be_true
  end

  it 'should handle nested expressions on both sides with negation' do
    ((@b1 & @b1) | @b3).must_not == ((@b1 | @b3) & @b2)
    @b1.must_be.true
    @b3.must_be.true
    sol = @model.solve!
    sol.b1.value.should be_true
    sol.b2.value.should_not be_true
    sol.b3.value.should be_true
  end

  it 'should translate reification with a variable right hand side' do
    @b1.must_be.equal_to(@b2, :reify => @b3)
    @b1.must_be.true
    @b2.must_be.false
    sol = @model.solve!
    sol.b3.value.should_not be_true
  end

  it 'should translate reification with a variable right hand side and negation'  do
    @b1.must_not_be.equal_to(@b2, :reify => @b3)
    @b1.must_be.true
    @b2.must_be.false
    sol = @model.solve!
    sol.b3.value.should be_true
  end
  
  it 'should raise error on right hand sides of incorrect type given to #==' do
    lambda{ @b1.must == 'hello' }.should raise_error(TypeError) 
  end

  it 'should raise error on right hand sides of incorrect type given to #imply' do
    lambda{ @b1.must.imply 'hello' }.should raise_error(TypeError) 
  end

  it_should_behave_like 'reifiable bool constraint'
end

[:&, :|, :^].each do |property|
  describe Gecode::Constraints::Bool, " (#{property} property)" do
    before do
      @model = BoolSampleProblem.new
      @b1 = @model.b1
      @b2 = @model.b2
      @model.branch_on @model.wrap_enum([@b1, @b2])

      # For bool operand producing property spec.
      @property_types = [:bool, :bool]
      @select_property = lambda do |bool1, bool2|
        bool1.method(property).call bool2
      end
      @selected_property = @b1.method(property).call @b2
    end

    it 'should constrain the conjunction/disjunction/exclusive disjunction' do
      (@b1.method(property).call @b2).must_be.true
      @model.solve!
      @b1.value.method(property).call(@b2.value).should be_true
    end

    it_should_behave_like('property that produces bool operand')
  end
end

describe Gecode::Constraints::Bool, ' (#implies property)' do
  before do
    @model = BoolSampleProblem.new
    @b1 = @model.b1
    @b2 = @model.b2
    @model.branch_on @model.wrap_enum([@b1, @b2])

    # For bool operand producing property spec.
    @property_types = [:bool, :bool]
    @select_property = lambda do |bool1, bool2|
      bool1.implies bool2
    end
    @selected_property = @b1.implies @b2
  end

  it 'should constrain the implication' do
    (@b1.implies @b2).must_be.true
    @model.solve!
    (!@b1.value | @b2.value).should be_true
  end

  it_should_behave_like('property that produces bool operand')
end
