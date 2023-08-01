class BasesController < ApplicationController
  def index
    @bases = Base.all
  end

  def new
    @base = Base.new
  end

  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = "拠点が追加されました。"
      redirect_to bases_index_path
    else
      render 'new'
    end
  end

  def edit
    @base = Base.find(params[:id])
  end

  def update
    @base = Base.find(params[:id])
    if @base.update(base_params)
      flash[:success] = "拠点情報が更新されました。"
      redirect_to bases_index_path
    else
      flash.now[:danger] = "拠点情報の更新に失敗しました。"
      render :edit
    end
  end

  def destroy
    @base = Base.find(params[:id])
    @base.destroy
    flash[:success] = "拠点が削除されました。"
    redirect_to bases_index_path
  end

  private

    def base_params
      params.require(:base).permit(:base_number, :base_name, :base_type)
    end
end
