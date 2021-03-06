# typed: strict
# frozen_string_literal: true

# Helper functions for generating release notes.
#
# @api private
module ReleaseNotes
  extend T::Sig

  module_function

  sig {
    params(start_ref: T.any(String, Version), end_ref: T.any(String, Version), markdown: T.nilable(T::Boolean))
      .returns(String)
  }
  def generate_release_notes(start_ref, end_ref, markdown: false)
    Utils.safe_popen_read(
      "git", "-C", HOMEBREW_REPOSITORY, "log", "--pretty=format:'%s >> - %b%n'", "#{start_ref}..#{end_ref}"
    ).lines.map do |s|
      matches = s.match(%r{.*Merge pull request #(?<pr>\d+) from (?<user>[^/]+)/[^>]*>> - (?<body>.*)})
      next if matches.blank?
      next if matches[:user] == "Homebrew"

      body = matches[:body].presence
      body ||= s.gsub(/.*(Merge pull request .*) >> - .*/, "\\1").chomp

      "- [#{body}](https://github.com/Homebrew/brew/pull/#{matches[:pr]}) (@#{matches[:user]})\n"
    end.compact.join
  end
end
