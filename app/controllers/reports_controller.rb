class ReportsController < ApplicationController
   skip_before_action :verify_authenticity_token
   $ceo_email = ENV['RAILS_ENV'] == 'development' ? 'trat.westerholt@gmail.com' : 'huper_05@mail.ru'

   def submit_report
      ActiveRecord::Base.transaction do
         user = User.find_by(steamID: params[:user][:steamID])
         return render json: {error: 'User not found'}, status: 404 if user.nil?

         
         return render json: {error: 'Вы не можете подать жалобу на себя'}, status: 404 if user.nickname == params[:suspect_nickname]

         report = Report.where(user_id: user.id, suspect_nickname: params[:suspect_nickname]).last
         return render json: {error: 'Вы не можете репортить одного и того же человека чаще, чем раз в час.'}, status: 400 if report.present? && report_time_diff(report) < 1

         result = Report.create(
            suspect_nickname: params[:suspect_nickname],
            details: params[:details],
            user_id: user.id
         )

         return render json: {error: 'Bad request'}, status: 400 unless result

         user.update(email: params[:user][:email])
         UserMailer.with(user: user, suspect: params[:suspect_nickname], report_id: result.id).report_email.deliver_now
         # ceo = User.find_by(email: "trat.westerholt@gmail.com")
         ceo = User.find_by(email: $ceo_email)

         UserMailer.with(ceo: ceo, user: user, suspect: params[:suspect_nickname], report_id: result.id).report_submitted_email.deliver_now
         render json: {
         status: 200
         }, status: 200
      end
   end

   def report_time_diff(report)
      ((report&.created_at - DateTime.now) / 1.hour).round * -1
   end
end