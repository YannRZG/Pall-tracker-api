class PaletteRecordsController < ApplicationController
  before_action :authenticate_user!

  def index
    # Tous les records liés à l'entreprise de l'utilisateur
    records = PaletteRecord
            .joins(:user_connection)
            .where(company: current_user.company)
            .where(user_connections: { status: :accepted })
            .includes(carrier: :company, shipper: :company, recipient: :company)
            .order(week: :desc)


    render json: records.as_json(
      methods: [:loading_debt, :delivery_debt],
      include: {
        carrier: { only: [:id], include: { company: { only: [:name] } } },
        shipper: { only: [:id], include: { company: { only: [:name] } } },
        recipient: { only: [:id], include: { company: { only: [:name] } } }
      }
    )
  end

  def create
    connection = UserConnection.find_by(
      shipper_id: palette_params[:shipper_id],
      carrier_id: palette_params[:carrier_id],
      status: :accepted
    )
  
    return render json: { error: 'Connexion non autorisée' }, status: :forbidden unless connection
  
    record = PaletteRecord.new(palette_params.except(:shipper_id, :carrier_id))
    record.user_connection = connection
    record.shipper = connection.shipper
    record.carrier = connection.carrier
    record.company = current_user.company

    unless current_user.admin? || record.shipper == current_user
      return render json: { error: 'Action non autorisée' }, status: :forbidden
    end
  
    if record.save
      render json: record, status: :created
    else
      render json: { errors: record.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  def update
    record = if current_user.admin?
               current_user.company.palette_records.find(params[:id])
             else
               current_user.palette_records.find(params[:id])
             end
  
    # 🔒 Sécurité métier : connexion valide
    unless record.user_connection&.accepted?
      return render json: { error: 'Connexion non autorisée' }, status: :forbidden
    end
  
    # 🔐 Protection : on ne permet PAS de changer la relation
    safe_params = palette_params.except(
      :shipper_id,
      :carrier_id,
      :recipient_id,
      :user_connection_id
    )
  
    if record.update(safe_params)
      render json: record.as_json(methods: [:loading_debt, :delivery_debt]), status: :ok
    else
      render json: { errors: record.errors.full_messages }, status: :unprocessable_entity
    end
  end
  
  private

  def palette_params
    params.require(:palette_record).permit(
      :week, :date, :rendered, :loaded,
      :transport, :loading_point, :delivery_point,
      :comment
    )
  end
end
