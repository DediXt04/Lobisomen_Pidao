import { Link } from "react-router-dom";

const Erro = () => {
  return (
    <div className="d-flex flex-column align-items-center justify-content-center vh-100 erro-404">
      <img
        src="/Lobo_Face.png"
        alt="Lobisomem perdido"
        className="erro-lobo mb-4"
      />
      <div className="text-center p-5 shadow rounded bg-white">
        <h1 className="display-1 fw-bold text-danger">404</h1>
        <h2 className="mb-3">Opa! O lobisomem se perdeu...</h2>
        <p className="text-muted mb-4">
          Essa página não existe. Parece que o lobo foi longe demais procurando
          comida! 🐺
        </p>
        <Link to="/" className="btn btn-primary btn-lg">
          🏠 Voltar para Home
        </Link>
      </div>
    </div>
  );
};

export default Erro;
