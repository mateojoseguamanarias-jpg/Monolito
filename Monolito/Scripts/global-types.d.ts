interface Window {
  actualizarBarra: (barId: string, valor: string, tipo: 'email' | 'pass') => void;
  Swal?: {
    fire: (options: unknown) => void;
  };
  PageMethods?: {
    Autenticar: (
      email: string,
      pass: string,
      onSuccess: (resultado: string) => void,
      onError: (err: { get_message?: () => string }) => void
    ) => void;
    AutenticarQR: (
      qrData: string,
      onSuccess: (resultado: string) => void,
      onError: (err: { get_message?: () => string }) => void
    ) => void;
  };
}

declare const Swal: {
  fire: (options: unknown) => void;
};

declare const PageMethods: {
  Autenticar: (
    email: string,
    pass: string,
    onSuccess: (resultado: string) => void,
    onError: (err: { get_message?: () => string }) => void
  ) => void;
  AutenticarQR: (
    qrData: string,
    onSuccess: (resultado: string) => void,
    onError: (err: { get_message?: () => string }) => void
  ) => void;
};
