using OpenQA.Selenium.Appium;
using OpenQA.Selenium.Appium.Windows;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace BrowserBowserAppTests
{
    [TestClass]
    public class BrowserBowserTests
    {
        private WindowsDriver<WindowsElement> _driver;

        [TestInitialize]
        public void Setup()
        {
            var appiumOptions = new AppiumOptions();
            appiumOptions.AddAdditionalCapability("app", @"C:\\Repos\\ghdemoreponov18\\BrowserBowserApp\\BrowserBowserApp\\bin\\Debug\\WebPopper.exe");
            appiumOptions.AddAdditionalCapability("platformName", "Windows");
            _driver = new WindowsDriver<WindowsElement>(new Uri("http://127.0.0.1:4723"), appiumOptions);
        }

        [TestMethod]
        public void TestButtonClick()
        {
            var button = _driver.FindElementByAccessibilityId("ButtonId");
            button.Click();
            var textBox = _driver.FindElementByAccessibilityId("TextBoxId");
            Assert.AreEqual("Expected Text", textBox.Text);
        }

        [TestCleanup]
        public void TearDown()
        {
            _driver.Quit();
        }
    }
}