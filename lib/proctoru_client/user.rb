class ProctoruClient::User
  attr_accessor :email,
                :first_name,
                :id,
                :last_name,
                :phone_number,
                :profile_completed,
                :time_zone,
                :address,
                :country,
                :city,
                :state,
                :zipcode
                
  def self.from_proctoru_api(json)
    ProctoruClient::User.new(id: json["student_id"],
             first_name: json["first_name"],
             last_name: json["last_name"],
             email: json["email"],
             phone_number: json["phone1"],
             profile_completed: json["profilecomplete"],
             time_zone: json["time_zone_id"],
             address: json["address"],
             country: json["country"],
             city: json["city"],
             state: json["state"],
             zipcode: json["zipcode"]
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
    @address = opts[:address]
    @country = opts[:country]
    @city = opts[:city],
    @state = opts[:state],
    @zipcode = opts[:zipcode]
    self
  end

  def to_s
    "#{id} #{first_name} #{last_name} <#{email}>"
  end

  def profile_completed?
    !!profile_completed
  end
end
