class Page < ActiveRecord::Base
  TEMPLATE_ELEMENTS = {
    'main' => ['banner','body']
  }
end
