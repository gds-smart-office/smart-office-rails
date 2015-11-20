class Date
  def weekday?
    [6, 0].exclude?(self.wday)
  end
end