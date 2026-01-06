import React from "react";

function Loading() {
  return (
    <div className="d-flex justify-content-center align-items-center vh-50">
      <div className="spinner-border text-primary" role="status">
        <span className="visually-hidden">Carregando...</span>
      </div>
    </div>
  );
}

export default Loading;
