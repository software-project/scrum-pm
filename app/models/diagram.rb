class Diagram < ActiveRecord::Base

  has_attachment :storage => :file_system,
                  :content_type => [:image, 'application/jpg'],
                  :max_size => 3000.kilobytes,
                  :resize_to => '1024x768>',
                  :thumbnails => { :thumb => '50x50>'},
                  :processor => :MiniMagick,
                  :path_prefix => 'public/attachments'


  belongs_to :user_story
  belongs_to :project

end
