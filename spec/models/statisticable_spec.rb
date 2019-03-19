require "rails_helper"

describe Statisticable do
  class DummyStats
    include Statisticable

    def participants
      User.all
    end
  end

  let(:stats) { DummyStats.new(nil) }

  describe "#gender?" do
    context "No participants" do
      it "is false" do
        expect(stats.gender?).to be false
      end
    end

    context "All participants have no defined gender" do
      before { create(:user, gender: nil) }

      it "is false" do
        expect(stats.gender?).to be false
      end
    end

    context "There's a male participant" do
      before { create(:user, gender: "male") }

      it "is true" do
        expect(stats.gender?).to be true
      end
    end

    context "There's a female participant" do
      before { create(:user, gender: "female") }

      it "is true" do
        expect(stats.gender?).to be true
      end
    end
  end

  describe "#age?" do
    context "No participants" do
      it "is false" do
        expect(stats.age?).to be false
      end
    end

    context "All participants have no defined age" do
      before { create(:user, date_of_birth: nil) }

      it "is false" do
        expect(stats.age?).to be false
      end
    end

    context "All participants have impossible ages" do
      before do
        create(:user, date_of_birth: 3.seconds.ago)
        create(:user, date_of_birth: 3000.years.ago)
      end

      it "is false" do
        expect(stats.age?).to be false
      end
    end

    context "There's a participant with a defined age" do
      before { create(:user, date_of_birth: 30.years.ago) }

      it "is true" do
        expect(stats.age?).to be true
      end
    end
  end

  describe "#geozone?" do
    context "No participants" do
      it "is false" do
        expect(stats.geozone?).to be false
      end
    end

    context "All participants have no defined geozone" do
      before { create(:user, geozone: nil) }

      it "is false" do
        expect(stats.geozone?).to be false
      end
    end

    context "There's a participant with a defined geozone" do
      before { create(:user, geozone: create(:geozone)) }

      it "is true" do
        expect(stats.geozone?).to be true
      end
    end
  end

  describe "#geozone_percentage?" do
    context "no participants" do
      it "is false" do
        expect(stats.geozone_percentage?).to be false
      end
    end

    context "All participants have no defined geozone" do
      before { create(:user, geozone: nil) }

      it "is false" do
        expect(stats.geozone_percentage?).to be false
      end
    end

    context "All participants belong to geozones with no population" do
      before { create(:user, geozone: create(:geozone)) }

      it "is false" do
        expect(stats.geozone_percentage?).to be false
      end
    end

    context "There's a participant from a geozone with population" do
      before do
        create(:user, geozone: create(:geozone))
        allow_any_instance_of(Geozone).to receive(:population).and_return(200)
      end

      it "is true" do
        expect(stats.geozone?).to be true
      end
    end
  end

  describe "#stats_methods" do
    it "includes total participants" do
      expect(stats.stats_methods).to include(:total_participants)
    end

    context "no gender stats" do
      before { allow(stats).to receive(:gender?).and_return(false) }

      it "doesn't include gender methods" do
        expect(stats.stats_methods).not_to include(:total_male_participants)
      end
    end

    context "no age stats" do
      before { allow(stats).to receive(:age?).and_return(false) }

      it "doesn't include age methods" do
        expect(stats.stats_methods).not_to include(:participants_by_age)
      end
    end

    context "no geozone stats" do
      before { allow(stats).to receive(:geozone?).and_return(false) }

      it "doesn't include age methods" do
        expect(stats.stats_methods).not_to include(:participants_by_geozone)
      end
    end

    context "all gender, age and geozone stats" do
      before do
        allow(stats).to receive(:gender?).and_return(true)
        allow(stats).to receive(:age?).and_return(true)
        allow(stats).to receive(:geozone?).and_return(true)
      end

      it "includes all stats methods" do
        expect(stats.stats_methods).to include(:total_male_participants)
        expect(stats.stats_methods).to include(:participants_by_age)
        expect(stats.stats_methods).to include(:participants_by_geozone)
      end
    end
  end
end
