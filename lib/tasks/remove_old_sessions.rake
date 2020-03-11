# frozen_string_literal: true

namespace :sessions do
  desc 'Remove old sessions'

  task remove_old_sessions: :environment do
    sessions.where('updated_at > ?', 30.days.ago).destroy_all
  end
end
