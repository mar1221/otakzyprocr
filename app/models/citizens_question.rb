# encoding: UTF-8

# == Schema Information
#
# Table name: citizens_questions
#
#  id          :integer          not null, primary key
#  citizen_id  :integer
#  question_id :integer
#  hours       :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  hours_done  :integer          default(0)
#

class CitizensQuestion < ActiveRecord::Base
  attr_accessible :citizen_id, :hours, :hours_done, :question_id
  belongs_to :citizen, :class_name => 'Refinery::Citizens::Citizen'
  belongs_to :question, :class_name => 'Refinery::Questions::Question'

  validate :format_of_promised_hours, :allowed_time_before_elections
  validate :no_more_promised_hours, on: :update
  validates :hours, numericality: { greater_than: 0, less_than_or_equal_to: 200, message: 'zadejte prosím číslo v rozmezí 1 - 200' }

  def paypal_url(return_url)
    values = {
      :business => '&rsquo;seller_1234111143_biz@asciicasts.com&rsquo;',
      :cmd => '&rsquo;_cart&rsquo;',
      :upload => 1,
      :return => return_url,
      :invoice => id,
      :amount => 5,
      :item_name => Rack::Utils.escape('Pocet hodin'),
      :item_quantity => self.hours
    }      
   
    if self.hours > 3
      case self.hours
        when 4
          values[:amount] = 12.50
        when 5
          values[:amount] = 10
        when 6
          values[:amount] = 8.50
        when 7
          values[:amount] = 7.50
        when 8
          values[:amount] = 6.50
        when 9
          values[:amount] = 6.00
        else
          values[:amount] = 5.00
      end
    end

    "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_xclick&business=otazky_1347886840_biz@gmail.com&item_name=#{values[:item_name]}&amount=#{values[:amount]}&quantity=#{values[:item_quantity]}&currency_code=CZK&return_url=http://otazkyprocr.herokuapp.com/payments/paypal/"
  end

  def format_of_promised_hours    
    if !hours.is_a?(Numeric) || !(hours > 0)
      errors.add(:hours, 'hodnota musí být kladné číslo')
    end    
  end

  def no_more_promised_hours
    hours_old = CitizensQuestion.find(id).hours

    if hours_old > hours_done
      errors.add(:hours, "ostáva Vám ješte #{hours - hours_done} přislíbených hodin.")
    end
  end

  def allowed_time_before_elections
    question = Refinery::Questions::Question.find(question_id)
    election = question.election
    time_to_election = (election.held.to_time - Time.now().to_time) / 60 / 60 / 24
    allowed_hours = (time_to_election * 4).round

    if allowed_hours < hours
      errors.add(:hours, "pro danou otázku je k dispozici maximálne #{allowed_hours} hodin.")
    end
  end
end