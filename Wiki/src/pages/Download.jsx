import React from 'react'
import { FiDownload, FiMonitor, FiHardDrive, FiCpu, FiCheckCircle } from 'react-icons/fi'

const Download = () => {

  const downloadUrl = '/downloads/LobisomenPidao_1_0.exe'

  const requisitos = [
    { icone: <FiMonitor size={20} />, label: 'Sistema Operacional', valor: 'Windows 10 ou superior' },
    { icone: <FiCpu size={20} />, label: 'Memória RAM', valor: '4 GB' },
    { icone: <FiHardDrive size={20} />, label: 'Espaço em disco', valor: '200 MB' },
  ]

  return (
    <div className="container py-4">
      <h2 className="mb-3">⬇️ Download do Jogo</h2>
      <p className="text-muted mb-4">
        Baixe a versão mais recente do jogo. O arquivo é o instalador do jogo para Windows.
      </p>

      <div className="row g-4 mb-5">
        <div className="col-md-6">
          <div className="card shadow border-0 h-100">
            <div className="card-body text-center py-5 d-flex flex-column justify-content-center">
              <FiDownload size={56} className="text-primary mb-3 mx-auto" />
              <h4 className="card-title fw-bold">Lobisomem Pidão — Demo</h4>
              <p className="text-muted mb-1">Versão mais recente</p>
              <span className="badge bg-secondary mb-3 mx-auto" style={{ width: 'fit-content' }}>Instalador Windows (.exe)</span>
              <a
                href={downloadUrl}
                download
                className="btn btn-primary btn-lg mt-2 mx-auto px-5"
              >
                <FiDownload className="me-2" />
                Baixar instalador
              </a>
            </div>
          </div>
        </div>

        <div className="col-md-6">
          <div className="card shadow-sm border-0 h-100">
            <div className="card-header bg-dark text-white fw-semibold">
              📋 Requisitos Mínimos
            </div>
            <ul className="list-group list-group-flush">
              {requisitos.map((r, i) => (
                <li key={i} className="list-group-item d-flex align-items-center gap-3">
                  <span className="text-primary">{r.icone}</span>
                  <div>
                    <small className="text-muted d-block">{r.label}</small>
                    <span className="fw-semibold">{r.valor}</span>
                  </div>
                </li>
              ))}
            </ul>
            <div className="card-footer bg-light">
              <div className="d-flex align-items-center gap-2 text-success">
                <FiCheckCircle />
                <small>Instalador para Windows — execute e siga os passos de instalação</small>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="card shadow-sm border-start border-info border-4">
        <div className="card-body">
          <h6 className="fw-bold mb-2">💡 Como jogar</h6>
          <ol className="mb-0">
            <li>Baixe o instalador (<code>.exe</code>) acima</li>
            <li>Execute o instalador e siga os passos para instalar o jogo</li>
            <li>Abra o jogo pelo atalho criado</li>
            <li>Conecte um gamepad (opcional) e divirta-se! 🐺</li>
          </ol>
        </div>
      </div>
    </div>
  )
}

export default Download