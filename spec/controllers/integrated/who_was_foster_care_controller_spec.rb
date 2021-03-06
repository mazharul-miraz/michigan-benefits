require "rails_helper"

RSpec.describe Integrated::WhoWasFosterCareController do
  describe "#skip?" do
    context "when someone in household was in foster care at age 18" do
      it "returns false" do
        application = create(:common_application,
          members: build_list(:household_member, 2, requesting_healthcare: "yes"),
          navigator: build(:application_navigator, anyone_foster_care_at_18: true))

        skip_step = Integrated::WhoWasFosterCareController.skip?(application)
        expect(skip_step).to be_falsey
      end
    end

    context "when no one in household was in foster care at age 18" do
      it "returns true" do
        application = create(:common_application,
          members: build_list(:household_member, 2, requesting_healthcare: "yes"),
          navigator: build(:application_navigator, anyone_foster_care_at_18: false))

        skip_step = Integrated::WhoWasFosterCareController.skip?(application)
        expect(skip_step).to be_truthy
      end
    end
  end

  describe "edit" do
    context "with a current application" do
      it "assigns members between 18 and 26, or with no birthday" do
        member1 = build(:household_member, birthday: 30.years.ago)
        member2 = build(:household_member, birthday: 20.years.ago)
        member3 = build(:household_member)
        current_app = create(:common_application,
          navigator: build(:application_navigator, anyone_foster_care_at_18: true),
          members: [member1, member2, member3])
        session[:current_application_id] = current_app.id

        get :edit

        form = assigns(:form)

        expect(form.members.count).to eq(2)
        expect(form.members.first).to eq(member2)
        expect(form.members.second).to eq(member3)
      end
    end
  end

  describe "#update" do
    context "with valid params" do
      let(:member_1) do
        create(:household_member)
      end

      let(:member_2) do
        create(:household_member)
      end

      let(:valid_params) do
        {
          members: {
            member_1.id => {
              foster_care_at_18: "no",
            },
            member_2.id => {
              foster_care_at_18: "yes",
            },
          },
        }
      end

      it "updates each member with foster care info" do
        current_app = create(:common_application, members: [member_1, member_2])
        session[:current_application_id] = current_app.id

        put :update, params: { form: valid_params }

        member_1.reload
        member_2.reload

        expect(member_1.foster_care_at_18_no?).to be_truthy
        expect(member_2.foster_care_at_18_yes?).to be_truthy
      end
    end

    context "with invalid params" do
      let(:member_1) do
        create(:household_member)
      end

      let(:member_2) do
        create(:household_member)
      end

      let(:invalid_params) do
        {
          members: {
            member_1.id => {
              foster_care_at_18: "no",
            },
            member_2.id => {
              foster_care_at_18: "no",
            },
          },
        }
      end

      it "renders edit without updating" do
        current_app = create(:common_application,
          members: [member_1, member_2],
          navigator: build(:application_navigator, anyone_foster_care_at_18: true))
        session[:current_application_id] = current_app.id

        put :update, params: { form: invalid_params }

        expect(response).to render_template(:edit)
      end
    end
  end
end
