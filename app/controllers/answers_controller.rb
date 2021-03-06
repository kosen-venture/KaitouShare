class AnswersController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource only: :stock

  before_action :authenticate_user!
  before_action :set_answer, only: [:show, :edit, :update, :destroy, :stock]
  before_action :set_universities, only: [:new, :edit, :create, :update]

  # GET /answers/1 
  # GET /answers/1.json
  def show
    @answer_files = @answer.answer_files
    @new_answer_file = AnswerFile.new(answer: @answer)
    @comment = Comment.new(user: current_user)
    @q = AnswerFile.search(params[:answer])
    @answers = @q.result(distinct: true)
  end

  # GET /answers/new
  def new
    @answer = Answer.new(user: current_user)
  end

  # GET /answers/1/edit
  def edit
  end

  # POST /answers
  # POST /answers.json
  def create
    @answer = Answer.new(answer_params)
    @answer.user = current_user

    respond_to do |format|
      if @answer.save
        format.html {
          redirect_to answer_path(@answer),
          notice: '作成しました。'
        }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /answers/1
  # PATCH/PUT /answers/1.json
  def update
    respond_to do |format|
      if @answer.update(answer_params)
        format.html {
          redirect_to answer_path(@answer),
            notice: '更新しました。'
        }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /answers/1
  # DELETE /answers/1.json
  def destroy
    dep = @answer.department
    @answer.destroy

    respond_to do |format|
      format.html { redirect_to university_department_path(dep.school.id, dep) }
    end
  end

  def stock
    # このページをストックしているか？
    if @answer.stocked?(current_user)
      # ストックしている
      # stockを削除
      @answer.stocks.where(user_id: current_user.id).delete_all

      # 元のページにリダイレクト
      redirect_to answer_path(@answer),
        notice: 'ストックを削除しました。'
    else
      # ストックしていない
      # stockを作成
      @answer.stocking_users << current_user

      # 元のページにリダイレクト
      redirect_to answer_path(@answer),
        notice: 'ストックに追加しました。'
    end
  end

  private
    def set_answer
      @answer = Answer.find(params[:id])
    end

    def set_universities
      @universities = University.all
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def answer_params
      params.require(:answer).permit(:university_id, :department_id, :subject, :year, :exam_url, :answer_text, answer_files_attributes: [:id, :order])
    end
end
