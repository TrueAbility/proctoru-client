class ExamityClient::User
  attr_accessor :email,
                :first_name,
                :id,
                :last_name,
                :phoneNumber,
                :profile_completed,
                :time_zone

  def self.from_examity_api(json)
    ExamityClient::User.new(id: json["userId"],
             first_name: json["firstName"],
             last_name: json["lastName"],
             email: json["emailAddress"],
             phone_number: json["phoneNumber"],
             profile_completed: json["profile_completed"],
             time_zone: json["timezone"]
            )
  end

  def initialize(opts = {})
    opts.symbolize_keys!

    @id = opts[:id]
    @first_name = opts[:first_name]
    @last_name = opts[:last_name]
    @email = opts[:email]
    @phone_number = opts[:phone_number]
    @profile_completed = opts[:profile_completed]
    @time_zone = opts[:time_zone]

    self
  end

  def to_s
    "#{id} #{first_name} #{last_name} <#{email}>"
  end

  def profile_completed?
    !!profile_completed
  end
end
