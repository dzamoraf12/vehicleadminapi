class FilteringService  
  def initialize(scope, filters, associations = [])
    @scope = scope.all
    @scope = scope.includes(*associations) if associations.any?
    @filters = filters
  end

  def filter
    @filters.each do |key, value|
      if value.present?
        @scope = @scope.public_send(key, value)
      end
    end

    @scope
  end
end
