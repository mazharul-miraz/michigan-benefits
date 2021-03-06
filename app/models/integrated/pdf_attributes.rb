module Integrated
  module PdfAttributes
    CIRCLED = "O".freeze
    UNDERLINED = "------------".freeze
    ORDINALS = %w[first second third fourth fifth].freeze

    def yes_no_or_unfilled(yes: nil, no: nil)
      if yes
        "Yes"
      elsif no
        "No"
      end
    end

    def yes_if_true(statement)
      "Yes" if statement
    end

    def underline_if_true(statement)
      UNDERLINED if statement
    end

    def circle_if_true(statement)
      CIRCLED if statement
    end

    def mmddyyyy_date(date, timezone = nil)
      if timezone
        date = date&.in_time_zone("Eastern Time (US & Canada)")
      end

      date&.strftime("%m/%d/%Y")
    end

    def member_names(members)
      members.map(&:display_name).join(", ")
    end

    def ordinal_member(i)
      "#{ORDINALS[i]}_member"
    end

    def yes_no_for(field)
      {
        yes: benefit_application.members.any?(&:"#{field}_yes?"),
        no: benefit_application.members.all?(&:"#{field}_no?"),
      }
    end
  end
end
