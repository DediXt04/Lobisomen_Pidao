import React from 'react'
import { FiDownload } from 'react-icons/fi'

const Download = () => {

  const downloadUrl = '/downloads/LobisomenPidao_Demo.exe'

  return (
    <div className="container py-4">
      <h2 className="mb-3">Download do Jogo</h2>
      <p className="text-muted mb-4">
        Baixe a versão mais recente do jogo. O arquivo está em formato <strong>.zip</strong> e
        contém o executável pronto para rodar.
      </p>

      <div className="card shadow-sm mb-4" style={{ maxWidth: '480px' }}>
        <div className="card-body text-center py-4">
          <FiDownload size={48} className="text-primary mb-3" />
          <h5 className="card-title">Jogo — Versão Demo</h5>
          <p className="card-text text-muted small">Plataforma: Windows &bull; Tamanho: —</p>
          <a
            href={downloadUrl}
            download
            className="btn btn-primary btn-lg mt-2"
          >
            <FiDownload className="me-2" />
            Baixar
          </a>
        </div>
      </div>

      <h5>Requisitos Mínimos</h5>
      <ul>
        <li>Sistema Operacional: Windows 10 ou superior</li>
        <li>Memória RAM: 4 GB</li>
        <li>Espaço em disco: 200 MB</li>
      </ul>
    </div>
  )
}

export default Download