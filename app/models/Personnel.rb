class Personnel
  include ActiveModel::Model
  
  attr_accessor :name, :start_date, :end_date, :description
  
  def within?(date)
    (end_date - start_date) < 365 && date.between?(start_date, end_date)    
  end
end