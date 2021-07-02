module Abilities
  class Administrator
    include CanCan::Ability

    def initialize(user)
      merge Abilities::Moderation.new(user)

      can :restore, Comment
      cannot :restore, Comment, hidden_at: nil

      can :restore, Debate
      cannot :restore, Debate, hidden_at: nil

      can :restore, Proposal
      cannot :restore, Proposal, hidden_at: nil

      can :create, Legislation::Proposal
      can :show, Legislation::Proposal
      can :proposals, ::Legislation::Process

      can :restore, Legislation::Proposal
      cannot :restore, Legislation::Proposal, hidden_at: nil

      can :restore, Budget::Investment
      cannot :restore, Budget::Investment, hidden_at: nil

      can :restore, User
      cannot :restore, User, hidden_at: nil

      can :restore, Topic
      cannot :restore, Topic, hidden_at: nil

      can :confirm_hide, Topic
      cannot :confirm_hide, Topic, hidden_at: nil

      can :confirm_hide, Comment
      cannot :confirm_hide, Comment, hidden_at: nil

      can :confirm_hide, Debate
      cannot :confirm_hide, Debate, hidden_at: nil

      can :confirm_hide, Proposal
      cannot :confirm_hide, Proposal, hidden_at: nil

      can :confirm_hide, Legislation::Proposal
      cannot :confirm_hide, Legislation::Proposal, hidden_at: nil

      can :confirm_hide, Budget::Investment
      cannot :confirm_hide, Budget::Investment, hidden_at: nil

      can :confirm_hide, User
      cannot :confirm_hide, User, hidden_at: nil

      can :mark_featured, Debate
      can :unmark_featured, Debate

      can :comment_as_administrator, [Debate, Comment, Proposal, Poll::Question, Budget::Investment,
                                      Legislation::Question, Legislation::Proposal, Legislation::Annotation,
                                      Topic, ProbeOption]
      can [:search, :create, :index, :destroy], ::Superadministrator
      can [:search, :create, :index, :destroy], ::Administrator
      can [:search, :create, :index, :destroy], ::SuresAdministrator
      can [:search, :create, :index, :destroy], ::SectionAdministrator
      can [:search, :create, :index, :destroy], ::Consultant
      can [:search, :create, :index, :destroy], ::Editor
      can [:search, :create, :index, :destroy], ::Moderator

      can [:search, :show, :edit, :update, :create, :index, :destroy, :summary], ::Valuator
      can [:search, :create, :index, :destroy], ::Manager
      can [:search, :index, :new, :destroy, :update_padron, :edit, :update], ::User
      can :manage, Profile

      can :manage, Dashboard::Action
      can :manage, EventAgend

      can [:index, :read, :new, :create, :update, :destroy, :calculate_winners], Budget
      can [:read, :create, :update, :destroy], Budget::Group
      can [:read, :create, :update, :destroy], Budget::Heading
      can [:hide, :update, :toggle_selection], Budget::Investment
      can [:valuate, :comment_valuation], Budget::Investment
      can :create, Budget::ValuatorAssignment
      can [:read_results], Budget, phase: "reviewing_ballots"

      can(:read_admin_stats, Budget) { |budget| budget.balloting_or_later? }

      can [:search, :edit, :update, :create, :index, :destroy], Banner

      can [:index, :create, :edit, :update, :destroy], Geozone

      can [:read, :create, :update, :destroy, :add_question, :search_booths, :search_officers, :booth_assignments, :results, :stats], Poll
      can [:read, :create, :update, :destroy, :available], Poll::Booth
      can [:search, :create, :index, :destroy], ::Poll::Officer
      can [:create, :destroy, :manage], ::Poll::BoothAssignment
      can [:create, :destroy], ::Poll::OfficerAssignment
      can [:read, :create, :update], Poll::Question
      can :destroy, Poll::Question # , comments_count: 0, votes_up: 0

      can :manage, SiteCustomization::Page
      can :manage, SiteCustomization::Image
      can :manage, SiteCustomization::ContentBlock

      can :access, :ckeditor
      can :manage, Ckeditor::Picture

      can [:manage], ::Sures::Actuation

      can [:manage], ::Legislation::Process
      can [:manage], ::Legislation::DraftVersion
      can [:manage], ::Legislation::Question
      can [:manage], ::Legislation::Proposal

      cannot :comment_as_moderator, [::Legislation::Question, Legislation::Annotation, ::Legislation::Proposal]

      can [:create], Document
      can [:destroy], Document, documentable_type: "Poll::Question::Answer"
      can [:create, :destroy], DirectUpload

      can [:deliver], Newsletter, hidden_at: nil
      can [:manage], Dashboard::AdministratorTask

      can :manage, ModeratedText
      can :create, ModeratedTexts::Import

      can :manage, ImportUser

      can :manage, Parbudget::Ambit
      can :manage, Parbudget::Project
      can :manage, Parbudget::Center
      can :manage, Parbudget::Meeting
      can :manage, Parbudget::Topic
      can :manage, Parbudget::Responsible
      
      can :manage, Parbudget::Editor
      can :manage, Parbudget::Reader

      can :manage, Complan::Editor
      can :manage, Complan::Reader

      can :manage, Complan::Project
      can :manage, Complan::Performance
      can :manage, Complan::Center
      can :manage, Complan::Financing
      can :manage, Complan::Strategy
      can :manage, Complan::Typology
      can :manage, Complan::ThecnicalTable

      can :manage, Audit
    end
  end
end
