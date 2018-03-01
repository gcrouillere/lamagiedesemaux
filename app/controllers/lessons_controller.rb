class LessonsController < ApplicationController
  layout 'stage'
  skip_before_action :authenticate_user!, only: [:show, :new]

  def show
    @lesson = Lesson.find(params[:id])
    @user = @lesson.user
    @order = Order.where(user: @user, state: "pending", lesson: @lesson).first
  end

  def new
    @dev_redirection = "https://www.creermonecommerce.fr/lessons/new"
    @lesson = Lesson.new
    @disabled_dates = full_bookings
    @first_possible_day = get_first_possible_day
    @confirmed_course_js_format = confirmed_courses
    @twitter_url = request.original_url.to_query('url')
  end

  def create
    unless /^(?:(?:31(\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\.)(?:0?[1,3-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\.)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$/.match("#{params[:lesson][:start]}")
      flash[:alert] = "Format de date invalide. Format attendu : JJ.MM.AAAA. Cliquez sur l'icône calendrier du formulaire"
      redirect_to new_lesson_path and return
    end

    if params[:lesson][:start].blank?
      flash[:alert] = "Veuillez sélectionner le 1er jour du stage"
      redirect_to new_lesson_path and return
    end

    if current_user.lessons.where(confirmed: false).present?
      flash[:alert] = "Vous avez déjà une demande de stage en cours"
      redirect_to new_lesson_path and return
    end

    @lesson = Lesson.new(lesson_params)
    @lesson.save

    if @lesson.start < Time.now
      @lesson.destroy
      flash[:alert] = "Veuillez sélectionner une date dans le futur"
      redirect_to new_lesson_path and return
    end

    for i in 0...@lesson.duration
      day_checked = @lesson.start + i.day
      booking = Booking.where(day: day_checked).first
      if booking.present?
        if booking.course != i + 1
          closest_start_answer = Findcloseststart.new(@lesson).closest_start(@lesson) # See service
          @lesson.destroy
          flash[:alert] = "Impossible de réserver. Jour(s) possible(s) pour début du stage : #{closest_start_answer}"
          redirect_to new_lesson_path and return
        end
        if @lesson.student > booking.capacity
          answer_min_capacity = min_capacity(@lesson)
          @lesson.destroy
          flash[:alert] = "Impossible de réserver. Plus que #{answer_min_capacity} places disponible sur la période demandée"
          redirect_to new_lesson_path and return
        end
      end
    end
    LessonMailer.mail_francoise_after_lesson_create(@lesson).deliver_now
    redirect_to stage_confirmation_path
  end

  def stage_confirmation
  end

  def stage_payment_confirmation
  end

  private

  def lesson_params
    params.require(:lesson).permit(:start, :duration, :student, :user_id)
  end

  def confirmed_courses
    day = ""
    month = ""
    confirmed_courses_js_format = []
    previous_booking_full = false
    Booking.order(day: :asc).all.each do |booking|
      if !booking.full && booking.day > Time.now && !(previous_booking_full && booking.course > 1)
        day = format_booking_to_moment(booking.day.day)
        month = format_booking_to_moment(booking.day.month)
        confirmed_courses_js_format << "#{day}/#{month}/#{booking.day.year}"
        previous_booking_full = false
      elsif booking.full || (previous_booking_full && booking.course > 1)
        previous_booking_full = true
      end
    end
    return confirmed_courses_js_format
  end

  def min_capacity(lesson)
    min_capacities = []
    for i in 0...lesson.duration
      day_checked = lesson.start + i.day
      min_capacities << Booking.where(day: day_checked).first.capacity
    end
    return min_capacities.min
  end

  def format_booking_to_moment(booking_day_or_month)
    output = ""
      if booking_day_or_month < 10
        output << "0"
      end
      output << booking_day_or_month.to_s
      return output
  end

  def full_bookings
    day = ""
    month = ""
    disabled_dates = []
    previous_booking_full = false
    Booking.order(day: :asc).all.each do |booking|
      day = format_booking_to_moment(booking.day.day)
      month = format_booking_to_moment(booking.day.month)
      if booking.full || (previous_booking_full && booking.course > 1)
        disabled_dates << "#{booking.day.year}-#{month}-#{day}"
        previous_booking_full = true
      else
          previous_booking_full = false
      end
    end
    return disabled_dates
  end

  def get_first_possible_day
    day_checked = Time.now.beginning_of_day + 1.day
    output = []
    for i in 0..365
      if Booking.where("day >= ? AND day <= ? AND capacity > ? ", day_checked.beginning_of_day, day_checked.end_of_day, 0).present? || Booking.where("day >= ? AND day <= ? ", day_checked.beginning_of_day, day_checked.end_of_day).empty?
        day = format_booking_to_moment(day_checked.day)
        month = format_booking_to_moment(day_checked.month)
        output << "#{day_checked.year}-#{month}-#{day}"
        return output
      end
      day_checked = day_checked + 1.day
    end
    return output
  end

end
