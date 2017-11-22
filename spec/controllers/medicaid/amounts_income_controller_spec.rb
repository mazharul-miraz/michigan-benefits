require "rails_helper"

RSpec.describe Medicaid::AmountsIncomeController do
  describe "#edit" do
    context "no one in the house has any income" do
      it "redirects to next step" do
        medicaid_application = create(
          :medicaid_application,
          anyone_employed: false,
          anyone_self_employed: false,
          anyone_other_income: false,
        )
        session[:medicaid_application_id] = medicaid_application.id

        get :edit

        expect(response).to redirect_to("/steps/medicaid/amounts-expenses")
      end
    end

    context "a single member in the household" do
      context "current member does not have income" do
        it "redirects to next step" do
          member = build(:member, employed: false)
          medicaid_application = create(
            :medicaid_application,
            members: [member],
            anyone_employed: true,
            anyone_self_employed: false,
            anyone_other_income: false,
          )
          session[:medicaid_application_id] = medicaid_application.id

          get :edit

          expect(response).to redirect_to("/steps/medicaid/amounts-expenses")
        end
      end

      context "household, and a client, has income" do
        it "renders edit" do
          member = build(:member, employed: true, employed_number_of_jobs: 2)
          medicaid_application = create(
            :medicaid_application,
            members: [member],
            anyone_employed: true,
            anyone_self_employed: false,
            anyone_other_income: false,
          )
          session[:medicaid_application_id] = medicaid_application.id

          get :edit

          expect(response).to render_template(:edit)
        end
      end
    end
  end

  describe "#update" do
    context "client has multiple jobs" do
      it "saves the income for each job" do
        member = build(:member, employed: true, employed_number_of_jobs: 2)
        medicaid_application = create(
          :medicaid_application,
          members: [member],
          anyone_employed: true,
        )
        session[:medicaid_application_id] = medicaid_application.id
        post :update, params: {
          step: {
            employed_pay_quantities: ["111", "222"],
            employed_employer_names: ["Co1", "Co2"],
            employed_payment_frequency: ["Monthly", "Monthly"],
            id: member.id,
          },
        }

        member.reload

        expect(member[:employed_pay_quantities]).to eq(%w(111 222))
        expect(member.employed_employer_names).to eq(%w(Co1 Co2))
        expect(member.employed_payment_frequency).to eq(%w(Monthly Monthly))
      end
    end
  end
end
