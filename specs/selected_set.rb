require File.dirname(__FILE__) + '/spec_helper'

describe Gecode::Constraints::SelectedSet::SelectedSetOperand do
  before do
    @model = Gecode::Model.new
    set_enum = @model.set_var_array(5, [], 0..9)
    set = @model.set_var([], 0..4)
    @operand = Gecode::Constraints::SelectedSet::SelectedSetOperand.new(
      set_enum, set)
  end

  it 'should implement #model' do
    @operand.model.should be_kind_of(Gecode::Model)
  end

  it 'should implement #to_selected_set' do
    enum, set = @operand.to_selected_set
    enum.should be_respond_to(:to_set_enum)
    set.should be_respond_to(:to_set_var)
    @model.solve!
    set_var = set.to_set_var
    ((set_var.lower_bound == []) && 
     (set_var.upper_bound == Gecode::Model::LARGEST_SET_BOUND)).should_not(
      be_true)
    enum.each do |element|
      set_var = element.to_set_var
      ((set_var.lower_bound == []) && 
       (set_var.upper_bound == Gecode::Model::LARGEST_SET_BOUND)).should_not(
        be_true)
    end
  end

  it 'should implement #must' do
    receiver = @operand.must
    receiver.should be_kind_of(
      Gecode::Constraints::SelectedSet::SelectedSetConstraintReceiver)
  end
end
