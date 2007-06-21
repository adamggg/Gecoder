require File.dirname(__FILE__) + '/spec_helper'
require 'set'

class SampleProblem < Gecode::Model
  attr :var
  attr :array
  attr :hash
  attr :nested_enum
  
  def initialize(domain)
    vars = self.int_var_array(1,domain)
    @var = vars.first
    @var.must > 1
    @array = [@var]
    @hash = {:a => var}
    @nested_enum = [1,2,[@var],[7, {:b => var}]]
    
    branch_on vars, :variable => :smallest_size, :value => :min
  end
end

describe Gecode::Model, ' (with multiple solutions)' do
  before do
    @domain = 0..3
    @solved_domain = [2]
    @model = SampleProblem.new(@domain)
  end

  it 'should pass a solution to the block given in #solution' do
    @model.solution do |s|
      s.var.should have_domain(@solved_domain)
    end
  end
  
  it 'should only evaluate the block for one solution in #solution' do
    i = 0
    @model.solution{ |s| i += 1 }
    i.should equal(1)
  end
  
  it 'should return the result of the block when calling #solution' do
    @model.solution{ |s| 'test' }.should == 'test'
  end
  
  it 'should pass every solution to #each_solution' do
    solutions = []
    @model.each_solution do |s|
      solutions << s.var.val
    end
    Set.new(solutions).should == Set.new([2,3])
  end
end

describe Gecode::Model, ' (after #solve!)' do
  before do
    @domain = 0..3
    @solved_domain = [2]
    @model = SampleProblem.new(@domain)
    @model.solve!
  end

  it 'should have updated the variables domains' do
    @model.var.should have_domain(@solved_domain)
  end

  it 'should have updated variables in arrays' do
    @model.array.first.should have_domain(@solved_domain)
  end
  
  it 'should have updated variables in hashes' do
    @model.hash.values.first.should have_domain(@solved_domain)
  end
  
  it 'should have updated variables in nested enums' do
    enum = @model.solve!.nested_enum
    enum[2].first.should have_domain(@solved_domain)
    enum[3][1][:b].should have_domain(@solved_domain)
    
    enum = @model.nested_enum
    enum[2].first.should have_domain(@solved_domain)
    enum[3][1][:b].should have_domain(@solved_domain)
  end
end

describe 'reset model', :shared => true do
  it 'should have reset variables' do
    @model.var.should have_domain(@reset_domain)
  end
  
  it 'should have reset variables in nested enums' do
    enum = @model.nested_enum
    enum[2].first.should have_domain(@reset_domain)
    enum[3][1][:b].should have_domain(@reset_domain)
  end
end

describe Gecode::Model, ' (after #reset!)' do
  before do
    @domain = 0..3
    @reset_domain = 2..3
    @model = SampleProblem.new(@domain)
    @model.solve!
    @model.reset!
  end
  
  it_should_behave_like 'reset model'
end

describe Gecode::Model, ' (after #solution)' do
  before do
    @domain = 0..3
    @reset_domain = 2..3
    @model = SampleProblem.new(@domain)
    @model.solution{ |s| }
  end
  
  it_should_behave_like 'reset model'
end

describe Gecode::Model, ' (after #each_solution)' do
  before do
    @domain = 0..3
    @reset_domain = 2..3
    @model = SampleProblem.new(@domain)
    @model.each_solution{ |s| }
  end
  
  it_should_behave_like 'reset model'
end

describe Gecode::Model, ' (without solution)' do
  before do
    @domain = 0..3
    @model = SampleProblem.new(@domain)
    @model.var.must < 0
  end
  
  it 'should return nil when calling #solution' do
    @model.var.must < 0
    @model.solution{ |s| 'test' }.should be_nil
  end
  
  it 'should return nil when calling #solve!' do
    @model.solve!.should be_nil
  end
end

describe Gecode::Model, ' (without constraints)' do
  before do
    @model = Gecode::Model.new
    @x = @model.int_var(0..1)
  end
  
  it 'should produce a solution' do
    @model.solve!.should_not be_nil
  end
end