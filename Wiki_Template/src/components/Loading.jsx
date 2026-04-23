function Loading() {
  return (
    <div className="loading-container d-flex flex-column justify-content-center align-items-center vh-50">
      <img
        src="/Lobo_Face.png"
        alt="Carregando..."
        className="loading-logo"
      />
      <span className="mt-3 text-muted">Carregando...</span>
    </div>
  );
}

export default Loading;
