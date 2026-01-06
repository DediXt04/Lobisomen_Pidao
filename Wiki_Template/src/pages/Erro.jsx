import React from "react";
import { Link } from "react-router-dom";


const Erro = () => {
  return (
    <div className="d-flex flex-column align-items-center justify-content-center vh-100">
      <div className="text-center p-5 shadow rounded bg-white">
        <h1 className="display-4 text-danger">404</h1>
        <h2 className="mb-3">Página não encontrada</h2>
        <p className="text-muted mb-4">
          O caminho que você tentou acessar não existe. Clique no botão abaixo
          para voltar à página inicial.
        </p>
        <Link to="/" className="btn btn-primary btn-lg">
          Voltar para Home
        </Link>
      </div>
    </div>
  );
};

export default Erro;
