class Date
  def to_s
    self.strftime('%d %b %Y, %a')    
  end
  
  def weekday?
    [6, 0].exclude?(self.wday)
  end
  
  def next_working_day
    newDate = self + 1
    while !newDate.weekday?
      newDate = newDate + 1
    end
    newDate
  end
end