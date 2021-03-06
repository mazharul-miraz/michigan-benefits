module Medicaid
  class ExpensesAlimonyController < MedicaidStepsController
    private

    def update_application
      super

      if single_member_household?
        current_application.primary_member.update!(member_attrs)
      end
    end

    def member_attrs
      {
        pay_child_support_alimony_arrears:
          step_params[:anyone_pay_child_support_alimony_arrears],
      }
    end
  end
end
