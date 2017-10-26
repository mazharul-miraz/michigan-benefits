# frozen_string_literal: true

module Medicaid
  class HealthPregnancyController < MedicaidStepsController
    private

    def after_successful_update_hook
      if single_member_household?
        current_application.primary_member.update!(member_attrs)
      end
    end

    def skip?
      all_males?
    end

    def all_males?
      current_application.members.all? do |member|
        member.sex == "male"
      end
    end

    def member_attrs
      { new_mom: step_params[:anyone_new_mom] }
    end
  end
end