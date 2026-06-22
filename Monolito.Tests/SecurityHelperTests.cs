using Capa_Datos;
using SimpleCrypto;

namespace Monolito.Tests;

[TestClass]
public class SecurityHelperTests
{
    [TestMethod]
    public void Encrypt_And_Decrypt_Should_Return_OriginalText()
    {
        // Arrange
        string originalText = "MensajeSecreto123!";

        // Act
        string cipherText = SecurityHelper.Encrypt(originalText);
        string decryptedText = SecurityHelper.Decrypt(cipherText);

        // Assert
        Assert.AreNotEqual(originalText, cipherText);
        Assert.AreEqual(originalText, decryptedText);
    }

    [TestMethod]
    public void VerifyFullHash_Should_Return_True_For_ValidOtp()
    {
        // Arrange
        string plainOtp = "123456";

        // Act
        string storedValue = SecurityHelper.GenerateFullHash(plainOtp);
        Console.WriteLine($"Stored Value: {storedValue}");
        string[] parts = storedValue.Split('|');
        var crypto = new PBKDF2();
        string recalculated = crypto.Compute(plainOtp, parts[1]);
        Console.WriteLine($"Parts[0]: {parts[0]}");
        Console.WriteLine($"Parts[1]: {parts[1]}");
        Console.WriteLine($"Recalculated: {recalculated}");

        bool isValid = SecurityHelper.VerifyFullHash(plainOtp, storedValue);

        // Assert
        Assert.IsTrue(isValid);
    }

    [TestMethod]
    public void VerifyFullHash_Should_Return_False_For_InvalidOtp()
    {
        // Arrange
        string plainOtp = "123456";
        string wrongOtp = "654321";

        // Act
        string storedValue = SecurityHelper.GenerateFullHash(plainOtp);
        bool isValid = SecurityHelper.VerifyFullHash(wrongOtp, storedValue);

        // Assert
        Assert.IsFalse(isValid);
    }
}
