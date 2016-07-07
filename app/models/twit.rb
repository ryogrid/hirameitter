# -*- coding: utf-8 -*-
class Twit < ActiveRecord::Base
  attr_accessible :id, :user_id, :text, :twit_id, :created_at, :parent_id
  belongs_to :user
  belongs_to :parent,
             :class_name => 'Twit',
             :foreign_key => 'parent_id'
  has_many   :children,
             :class_name => 'Twit',
             :foreign_key => 'parent_id'

  #子孫の数を返す
  def count_descendant
    if children.length > 0
      sum = 0
      children.each{ |each_child|
        sum += each_child.count_descendant() #each_childの子孫達の数を足しこむ
        sum += 1 #each_childを1つとカウント
      }
      return sum
    else
      return 0
    end
  end

  #先祖(直系ではないものも含む)と兄弟のIDの配列を返す
  def get_ancestors_and_brother()
    result = get_ancestors_inner()
    result.delete(self.id) #自分自身のIDが含まれてしまっているので取り除く

    return result
  end

  def get_ancestors_inner()
    result = children.collect{|each_twit| each_twit.id}
    if parent
      parent.get_ancestors_inner().each{ |each_id|
        result << each_id
      }
    else
      result << self.id
    end

    return result
  end

end
