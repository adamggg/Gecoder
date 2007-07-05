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
    
    # For constraint option spec.
    @invoke_options = lambda do |hash| 
      (@b1 | @b2).must_be.equal_to(true, hash) 
      @model.solve!
    end
    @expect_options = lambda do |strength, reif_var|
      Gecode::Raw.should_receive(:bool_or).once.with(@model.active_space, 
        @b1.bind, @b2.bind, an_instance_of(Gecode::Raw::BoolVar), 
        Gecode::Raw::ICL_DEF)
      unless reif_var.nil?
        Gecode::Raw.should_receive(:bool_eqv).once.with(@model.active_space, 
          an_instance_of(Gecode::Raw::BoolVar), reif_var.bind, true, strength)
      end
    end
  end
  
  it 'should handle single variables constrainted to be true' do
    @b1.must_be.true
    b1 = @model.solve!.b1
    b1.should be_assigned
    b1.true?.should be_true
  end
  
  it 'should handle single variables constrainted to be false' do
    @b1.must_be.false
    b1 = @model.solve!.b1
    b1.should be_assigned
    b1.true?.should_not be_true
  end
  
  it 'should handle single variables constrainted not to be false' do
    @b1.must_not_be.false
    b1 = @model.solve!.b1
    b1.should be_assigned
    b1.true?.should be_true
  end
  
  it 'should handle single variables constrainted not to be true' do
    @b1.must_not_be.true
    b1 = @model.solve!.b1
    b1.should be_assigned
    b1.true?.should_not be_true
  end

  it 'should handle disjunction' do
    @b1.must_be.false
    (@b1 | @b2).must_be.true
    sol = @model.solve!
    sol.b1.true?.should_not be_true
    sol.b2.true?.should be_true
  end
  
  it 'should handle negated disjunction' do
    @b1.must_be.false
    (@b1 | @b2).must_not_be.true
    sol = @model.solve!
    sol.b1.true?.should_not be_true
    sol.b2.true?.should_not be_true
  end
  
  it 'should handle conjunction' do
    (@b1 & @b2).must_be.true
    sol = @model.solve!
    sol.b1.true?.should be_true
    sol.b2.true?.should be_true
  end

  it 'should handle negated conjunction' do
    @b1.must_be.true
    (@b1 & @b2).must_not_be.true
    sol = @model.solve!
    sol.b1.true?.should be_true
    sol.b2.true?.should_not be_true
  end

  it 'should handle exclusive or' do
    @b1.must_be.false
    (@b1 ^ @b2).must_be.true
    sol = @model.solve!
    sol.b1.true?.should_not be_true
    sol.b2.true?.should be_true
  end

  it 'should handle negated exclusive or' do
    @b1.must_be.true
    (@b1 ^ @b2).must_not_be.true
    sol = @model.solve!
    sol.b1.true?.should be_true
    sol.b2.true?.should be_true
  end

  it 'should handle single variables as right hand side' do
    @b1.must == @b2
    @b2.must_be.false
    sol = @model.solve!
    sol.b1.true?.should_not be_true
    sol.b2.true?.should_not be_true
  end
  
  it 'should handle single variables with negation as right hand side' do
    @b1.must_not == @b2
    @b2.must_be.false
    sol = @model.solve!
    sol.b1.true?.should be_true
    sol.b2.true?.should_not be_true
  end
  
  it 'should handle expressions as right hand side' do
    @b1.must == (@b2 | @b3)
    @b2.must_be.true
    sol = @model.solve!
    sol.b1.true?.should be_true
    sol.b2.true?.should be_true
  end
  
  it 'should handle nested expressions as left hand side' do
    ((@b1 & @b2) | @b3 | (@b1 & @b3)).must_be.true
    @b1.must_be.false
    sol = @model.solve!
    sol.b1.true?.should_not be_true
    sol.b3.true?.should be_true
  end
  
  it 'should handle nested expressions on both side' do
    ((@b1 & @b1) | @b3).must == ((@b1 & @b3) & @b2)
    @b1.must_be.true
    sol = @model.solve!
    sol.b1.true?.should be_true
    sol.b2.true?.should be_true
    sol.b3.true?.should be_true
  end
  
  it 'should handle nested expressions containing exclusive or' do
    ((@b1 ^ @b1) & @b3).must == ((@b2 | @b3) ^ @b2)
    @b1.must_be.true
    @b2.must_be.false
    sol = @model.solve!
    sol.b1.true?.should be_true
    sol.b2.true?.should_not be_true
    sol.b3.true?.should_not be_true
  end
  
  it 'should handle nested expressions on both sides with negation' do
    ((@b1 & @b1) | @b3).must_not == ((@b1 | @b3) & @b2)
    @b1.must_be.true
    @b3.must_be.true
    sol = @model.solve!
    sol.b1.true?.should be_true
    sol.b2.true?.should_not be_true
    sol.b3.true?.should be_true
  end
  
  it 'should translate reification with a variable right hand side' do
    @b1.must_be.equal_to(@b2, :reify => @b3)
    @b1.must_be.true
    @b2.must_be.false
    sol = @model.solve!
    sol.b3.true?.should_not be_true
  end
  
  it 'should translate reification with a variable right hand side and negation' do
    @b1.must_not_be.equal_to(@b2, :reify => @b3)
    @b1.must_be.true
    @b2.must_be.false
    sol = @model.solve!
    sol.b3.true?.should be_true
  end
  
  
  it_should_behave_like 'constraint with options'
end